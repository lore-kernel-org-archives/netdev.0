From: "nano bug" <linnewbye@gmail.com>
Subject: Fwd: source interface ping bug ?
Date: Thu, 2 Aug 2007 23:01:37 +0300
Message-ID: <d39c36500708021301i6754cb6bh4ba1a2a85092ce3c@mail.gmail.com>
References: <d39c36500707270130j3eac7f44qb3a4c87496a1296b@mail.gmail.com>
	 <46AE0F9E.5030003@trash.net>
	 <d39c36500708021258v1b45c3d1q2656bd3cdd9477f7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_100201_23924053.1186084897175"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:43665 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758243AbXHBUBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 16:01:39 -0400
Received: by mu-out-0910.google.com with SMTP id i10so759389mue
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2007 13:01:37 -0700 (PDT)
In-Reply-To: <d39c36500708021258v1b45c3d1q2656bd3cdd9477f7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_100201_23924053.1186084897175
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

---------- Forwarded message ----------
From: nano bug <linnewbye@gmail.com>
Date: Aug 2, 2007 10:58 PM
Subject: Re: source interface ping bug ?
To: Patrick McHardy <kaber@trash.net>


Hello,

Yes I'm running NAT, I have atached the output of the iptables -t nat
-vxnL command and the routing tables

On 7/30/07, Patrick McHardy <kaber@trash.net> wrote:
> nano bug wrote:
> > [...]
> > using source interface :
> >
> > root@darkstar:~/iputils# ./ping -I eth2 87.248.113.14
> > PING 87.248.113.14 (87.248.113.14) from 86.106.19.75 eth2: 56(84) bytes of data.
> >>From 86.106.19.75 icmp_seq=1 Destination Host Unreachable
>
> > root@darkstar:~# tcpdump -i eth2 -vvv -n host 87.248.113.14 and host
> > 86.106.19.75
> > tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size 96 bytes
> > 01:19:24.292911 arp who-has 87.248.113.14 tell 86.106.19.75
>
>
> Are you using (or running) NAT locally? What do your routing tables look
> like?
>

------=_Part_100201_23924053.1186084897175
Content-Type: application/octet-stream; name=route_tables
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f4vo22r6
Content-Disposition: attachment; filename="route_tables"

cm9vdEBkYXJrc3Rhcjp+Iwpyb290QGRhcmtzdGFyOn4jCnJvb3RAZGFya3N0YXI6fiMgaXAgcm91
dGUgc2hvdwo4MC45Ny43MS4wLzI0IGRldiBldGgwICBwcm90byBrZXJuZWwgIHNjb3BlIGxpbmsg
IHNyYyA4MC45Ny43MS4yMwoxMC4xMC4xMC4wLzI0IGRldiBldGgxICBwcm90byBrZXJuZWwgIHNj
b3BlIGxpbmsgIHNyYyAxMC4xMC4xMC4xCjg2LjEwNi4xOC4wLzIzIGRldiBldGgyICBzY29wZSBs
aW5rCjEyNy4wLjAuMC84IGRldiBsbyAgc2NvcGUgbGluawpyb290QGRhcmtzdGFyOn4jIGlwIHJ1
bGUgc2hvdwowOiAgICAgIGZyb20gYWxsIGxvb2t1cCBsb2NhbAo1MDogICAgIGZyb20gYWxsIGxv
b2t1cCBtYWluCjEwMDogICAgZnJvbSA4MC45Ny43MS4wLzI0IGxvb2t1cCAyMDEKMTAxOiAgICBm
cm9tIDg2LjEwNi4xOC4wLzIzIGxvb2t1cCAyMDIKMTAyOiAgICBmcm9tIGFsbCBsb29rdXAgMjIy
CjMyNzY2OiAgZnJvbSBhbGwgbG9va3VwIG1haW4KMzI3Njc6ICBmcm9tIGFsbCBsb29rdXAgZGVm
YXVsdApyb290QGRhcmtzdGFyOn4jIGlwIHJvdXRlIHNob3cgdGFibGUgMjAxCmRlZmF1bHQgdmlh
IDgwLjk3LjcxLjEgZGV2IGV0aDAgIHByb3RvIHN0YXRpYwpwcm9oaWJpdCBkZWZhdWx0ICBwcm90
byBzdGF0aWMgIG1ldHJpYyAxCnJvb3RAZGFya3N0YXI6fiMgaXAgcm91dGUgc2hvdyB0YWJsZSAy
MDIKZGVmYXVsdCB2aWEgODYuMTA2LjE4LjEgZGV2IGV0aDIgIHByb3RvIHN0YXRpYwpwcm9oaWJp
dCBkZWZhdWx0ICBwcm90byBzdGF0aWMgIG1ldHJpYyAxCnJvb3RAZGFya3N0YXI6fiMgaXAgcm91
dGUgc2hvdyB0YWJsZSAyMjIKZGVmYXVsdCAgcHJvdG8gc3RhdGljCiAgICAgICAgbmV4dGhvcCB2
aWEgODAuOTcuNzEuMSAgZGV2IGV0aDAgd2VpZ2h0IDEKICAgICAgICBuZXh0aG9wIHZpYSA4Ni4x
MDYuMTguMSAgZGV2IGV0aDIgd2VpZ2h0IDk5CnByb2hpYml0IGRlZmF1bHQgIHByb3RvIHN0YXRp
YyAgbWV0cmljIDEKcm9vdEBkYXJrc3Rhcjp+IyBpcHRhYmxlcyAtVgppcHRhYmxlcyB2MS4zLjgK
cm9vdEBkYXJrc3Rhcjp+IyBpcHRhYmxlcyAtdCBuYXQgLXh2bkwKQ2hhaW4gUFJFUk9VVElORyAo
cG9saWN5IEFDQ0VQVCAyMTIwIHBhY2tldHMsIDI5ODEzNCBieXRlcykKICAgIHBrdHMgICAgICBi
eXRlcyB0YXJnZXQgICAgIHByb3Qgb3B0IGluICAgICBvdXQgICAgIHNvdXJjZSAgICAgICAgICAg
ICAgIGRlc3RpbmF0aW9uCiAgICAgICAxICAgICAgIDQ4IEROQVQgICAgICAgdGNwICAtLSAgZXRo
MiAgICogICAgICAgMC4wLjAuMC8wICAgICAgICAgICAgMC4wLjAuMC8wICAgICAgICAgICB0Y3Ag
ZHB0czoxODg1NjoxODg3MCB0bzoxNzIuMTYuMi4xCiAgICAgICAwICAgICAgICAwIEROQVQgICAg
ICAgdWRwICAtLSAgZXRoMiAgICogICAgICAgMC4wLjAuMC8wICAgICAgICAgICAgMC4wLjAuMC8w
ICAgICAgICAgICB1ZHAgZHB0czoxODg1NjoxODg3MCB0bzoxNzIuMTYuMi4xCgpDaGFpbiBQT1NU
Uk9VVElORyAocG9saWN5IEFDQ0VQVCA1NiBwYWNrZXRzLCA0NTY4IGJ5dGVzKQogICAgcGt0cyAg
ICAgIGJ5dGVzIHRhcmdldCAgICAgcHJvdCBvcHQgaW4gICAgIG91dCAgICAgc291cmNlICAgICAg
ICAgICAgICAgZGVzdGluYXRpb24KICAgICAgIDIgICAgICAxMzggTUFTUVVFUkFERSAgYWxsICAt
LSAgKiAgICAgICogICAgICAgMTAuMTAuMTAuMC8yNCAgICAgICAgMC4wLjAuMC8wCiAgICAgICAw
ICAgICAgICAwIE1BU1FVRVJBREUgIGFsbCAgLS0gICogICAgICAqICAgICAgIDE3Mi4xNi4xLjAv
MjQgICAgICAgIDAuMC4wLjAvMAogICAgICAgMCAgICAgICAgMCBNQVNRVUVSQURFICBhbGwgIC0t
ICAqICAgICAgKiAgICAgICAxNzIuMTYuMi4wLzI0ICAgICAgICAwLjAuMC4wLzAKCkNoYWluIE9V
VFBVVCAocG9saWN5IEFDQ0VQVCA1NSBwYWNrZXRzLCA0NTIwIGJ5dGVzKQogICAgcGt0cyAgICAg
IGJ5dGVzIHRhcmdldCAgICAgcHJvdCBvcHQgaW4gICAgIG91dCAgICAgc291cmNlICAgICAgICAg
ICAgICAgZGVzdGluYXRpb24Kcm9vdEBkYXJrc3Rhcjp+IwoKCg==
------=_Part_100201_23924053.1186084897175--
