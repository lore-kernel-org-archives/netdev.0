From: Jeff Garzik <jgarzik@pobox.com>
Subject: NAPI interrupt data
Date: Sat, 15 Feb 2003 02:16:44 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3E4DE95C.2050804@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050203000908090607000205"
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050203000908090607000205
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I looked at my latest tg3 driver's activity in /proc/interrupts and was 
a bit surprised.  Using "ttcp" to send 500,000 bursts from a 
uniprocessor P3 ("hum") to a dual athlon ("crumb"), I recorded the 
interrupts using the simple

	while true
	do
		cat /proc/interrupts >> data
		sleep 1
	done

method.  On hum, eth0 shared interrupts with acpi.  On crumb, eth0 
shared interrupts with the potentially-skewing aic7xxx.  The results of 
tg3[NAPI] one ttcp process on unloaded boxes are the following, in 
"approximate packets per second":

bash-2.05b$ ./x.pl data.crumb
135 samples, 21578 avg
bash-2.05b$ ./x.pl data.hum
130 samples, 11213 avg

The raw sample data and compute-the-average perl script were so small 
that I simply attached them to this email.  Feel free to check my math 
for something dumb.

	Jeff



--------------050203000908090607000205
Content-Type: application/octet-stream;
 name="interrupt-data.tar.bz2"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="interrupt-data.tar.bz2"

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
aa23IF/xdyRThQkLFHR+QA==
--------------050203000908090607000205--

