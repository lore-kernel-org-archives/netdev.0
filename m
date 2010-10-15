From: Patrick Ringl <patrick_@freenet.de>
Subject: 2.6.36-rc7: net/bridge causes temporary network I/O lockups
Date: Sat, 16 Oct 2010 01:04:07 +0200
Message-ID: <4CB8DDE7.9080501@freenet.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4499131260005349203=="
Cc: herbert@gondor.hengli.com.au, bridge@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Mime-version: 1.0
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============4499131260005349203==
Content-Type: multipart/alternative;
 boundary="------------030607070400000506030901"

This is a multi-part message in MIME format.
--------------030607070400000506030901
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

after I recently switched from 2.6.32 to 2.6.35 (and for testing to 
2.6.36-rc7) I had massive issues with temporarily occurring freezes 
regarding the whole network stack.
The freezes are occurring randomly and usually take 20-30 seconds until 
the system is responsive again (in addition locally thus with a screen 
and keyboard attached the system is still fully functional).

I noticed that this behavior only occurs once I have a bridge set up for 
KVM (with one local interface configured as port, fd and maxwait set to 
0). If I disable the bridge and configure the interfaces with an IP, 
things are back to normal and thus everything works fine.

The network hardware in question was an nforce onboard controller (using 
dethforce) and the 2nd interface I have the exact same issue with is a 
realtek using r8169.

So here it is: Could commit 573201f36fd9c7c6d5218cdcd9948cee700b277d ( 
partially disabling netpoll support) be the issue for the problem I am 
currently facing? If not, what could it be then?


Please CC to me since I am not subscribed! :-)



regards,
Patrick

--------------030607070400000506030901
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>

<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
</head>
<body text="#000000" bgcolor="#ffffff">
Hi,<br>
<br>
after I recently switched from 2.6.32 to 2.6.35 (and for testing to
2.6.36-rc7) I had massive issues with temporarily occurring freezes
regarding the whole network stack.<br>
The freezes are occurring randomly and usually take 20-30 seconds until
the system is responsive again (in addition locally thus with a screen
and keyboard attached the system is still fully functional).<br>
<br>
I noticed that this behavior only occurs once I have a bridge set up
for KVM (with one local interface configured as port, fd and maxwait
set to 0). If I disable the bridge and configure the interfaces with an
IP, things are back to normal and thus everything works fine.<br>
<br>
The network hardware in question was an nforce onboard controller
(using dethforce) and the 2nd interface I have the exact same issue
with is a realtek using r8169.<br>
<br>
So here it is: Could commit 573201f36fd9c7c6d5218cdcd9948cee700b277d (
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
<span class="Apple-style-span"
 style="border-collapse: separate; color: rgb(0, 0, 0); font-family: 'Times New Roman'; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: normal; orphans: 2; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; font-size: medium;">partially
disabling netpoll support) </span>be the issue for the problem I am
currently facing? If not, what could it be then? <br>
<br>
<br>
Please CC to me since I am not subscribed! :-)<br>
<br>
<br>
<br>
regards,<br>
Patrick<br>
<span class="Apple-style-span"
 style="border-collapse: separate; color: rgb(0, 0, 0); font-family: 'Times New Roman'; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: normal; orphans: 2; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; font-size: medium;"><span
 class="Apple-style-span"
 style="font-family: monospace; font-size: 12px;"></span></span>
</body>
</html>

--------------030607070400000506030901--

--===============4499131260005349203==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/bridge
--===============4499131260005349203==--
