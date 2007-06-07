From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Thu, 7 Jun 2007 11:46:25 +0530
Message-ID: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
References: <1181137761.4068.22.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=EABBF860DF8EDEA88f9e8a93df938690918cEABBF860DF8EDEA8"
Cc: Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:44018 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737AbXFGGTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 02:19:12 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l576dvxU300002
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 16:39:57 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l576M4JD207218
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 16:22:20 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l576HUJk010131
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 16:17:30 +1000
In-Reply-To: <1181137761.4068.22.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--0__=EABBF860DF8EDEA88f9e8a93df938690918cEABBF860DF8EDEA8
Content-type: text/plain; charset=US-ASCII

My somewhat confusing netperf script (to run on client) is attached below.
Server just requires
to run netserver. Client is not completely accurate since I am not using
netperf4 (moving to
that after some initial hiccups).

thanks,

- KK

(See attached file: netperf.scp)


J Hadi Salim <j.hadi123@gmail.com> wrote on 06/06/2007 07:19:21 PM:

> Folks,
>
> While Krishna and I have been attempting this on the side, progress has
> been rather slow - so this is to solicit for more participation so we
> can get this over with faster. Success (myself being conservative when
> it comes to performance) requires testing on a wide variety of hardware.
>
> The results look promising - certainly from a pktgen perspective where
> performance has been known in some cases to go up over 50%.
> Tests by Sridhar on a low number of TCP flows also indicate improved
> performance as well as lowered CPU use.
>
> I have setup the current state of my patches against Linus tree at:
> git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-lin26.git
>
> This is also clean against 2.6.22-rc4. So if you want just a diff that
> will work against 2.6.22-rc4 - i can send it to you.
> I also have a tree against Daves net-2.6 at
> git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-net26.git
> but iam abandoning that effort until we get this stable due to the
> occasional bug that cropped up(like e1000).
>
> I am attaching a pktgen script. There is one experimental parameter
> called "batch_low" - for starters just leave it at 0 in order to reduce
> experimental variance. If you have solid results you can muck around
> with it.
> KK has a netperf script he has been using - if you know netperf your
> help will really be appreciated in testing it on your hardware.
> KK, can you please post your script?
> Testing with forwarding and bridging will also be appreaciated.
> Above that, suggestions to changes as long as they are based on
> verifiable results or glaringly obvious changes are welcome. My
> preference at the moment is to flesh out the patch as is and then
> improve on it later if it shows it has some value on a wide variety of
> apps. As the subject is indicating this is a WIP and as all eulas
> suggest "subject to change without notice".
> If you help out, when you post your results, can you please say what
> hardware and setup was?
>
> The only real driver that has been changed is e1000 for now. KK is
> working on something infiniband related and i plan (if noone beats me)
> to get tg3 working. It would be nice if someone converted some 10G
> ethernet driver.
>
> cheers,
> jamal
> [attachment "pktgen.batch-1-1" deleted by Krishna Kumar2/India/IBM]
--0__=EABBF860DF8EDEA88f9e8a93df938690918cEABBF860DF8EDEA8
Content-type: application/octet-stream;
	name="netperf.scp"
Content-Disposition: attachment; filename="netperf.scp"
Content-transfer-encoding: base64

dHlwZXNldCAtaSBpCnR5cGVzZXQgLWkgcAoKI3NlcnZlcj0xOTIuMTY4LjEuMgplY2hvICJTZXQg
dGhlIHNlcnZlciBJUCBhZGRyZXNzIGhlcmUgYW5kIHJlbW92ZSB0aGUgbmV4dCBsaW5lIgpleGl0
CgppZiBbICQjIC1uZSAxIF0KdGhlbgoJZWNobyAiUmVxdWlyZSBhIHVuaXF1ZSBmaWxlbmFtZSB0
byBvdXRwdXQgcmVzdWx0cyIKCWV4aXQKZmkKCm1rZGlyIC1wIHJlc3VsdHMKCnJlcz1yZXN1bHRz
LyQxCmlmIFsgLWYgJHJlcyAtbyAtZCAkcmVzIF0KdGhlbgoJZWNobyAiJHJlcyBhbHJlYWR5IGV4
aXN0cywgcHJvdmlkZSBhIHVuaXF1ZSBuYW1lIgoJZXhpdApmaQoKbWtkaXIgJHJlcyA+IC9kZXYv
bnVsbCAyPiYxCgojIFRoaXMgcGFydGljdWxhciBydW4gY29tYmluYXRpb24gKG9mIHRpbWUvdGVz
dHMvcHJvY3MvYnVmZmVyIHNpemVzKSB0YWtlcwojIGFib3V0IDEgaG91ciAzNCBtaW5zIHRvIGZp
bmlzaC4KCiMgVGltZSB0byBydW4KVElNRT0xODAKCiMgVmFyaW91cyBidWZmZXIgc2l6ZXMKUz0i
OCAzMiAxMjggNTEyIDQwOTYiCgojIFNldCB0aGUgbnVtYmVyIG9mIHBhcmFsbGVsIG5ldHBlcmZz
ClA9IjEgMzIiCgojIFNob3VsZCBzZXQgdGhlIHNlbmQvcmVjZWl2ZSBzb2NrZXQgc2l6ZXMgc28g
YXMgdG8gaGF2ZSB1bmlmb3JtIGVudmlyb25tZW50CiMgZm9yIGV2ZXJ5IHJ1bi4gVGhpcyBjYW4g
YmUgZWFzaWx5IGRvbmUgYnkgbW9kaWZ5aW5nIHRoZSBuZXRwZXJmIGNvbW1hbmQKCmVjaG8gIlN0
YXJ0aW5nIGF0IDogYGRhdGVgIiA+ICRyZXMvREFURQpmb3Igc2l6ZSBpbiAkUwpkbwoJZm9yIHAg
aW4gJFAKCWRvCgkoCgkJZWNobyAiRTEwMDAgUnVubmluZyAkcCBUQ1AgVGVzdChzKSBzaXplOiRz
aXplIGRlbGF5OiIKCQlzeW5jCgkJaT0wCgkJd2hpbGUgWyAkaSAtbHQgJHAgXQoJCWRvCgkJCWVj
aG8gIm5ldHBlcmYgLWMgLUMgLXYgMSAtdCBUQ1BfU1RSRUFNIFwKCQkJCS1JOTksNSAtbCAkVElN
RSAtSCAkc2VydmVyIC0tIC1tICRzaXplIFwKCQkJCS1NICRzaXplICYiCgkJCWk9JGkrMQoJCWRv
bmUKCQl3YWl0CgkpID4+ICRyZXMvdGNwLiRwIDI+JjEKCWRvbmUKCglmb3IgcCBpbiAkUAoJZG8K
CSgKCQllY2hvICJFMTAwMCBSdW5uaW5nICRwIFRDUChzKSBUZXN0IHNpemU6JHNpemUgZGVsYXk6
LUQiCgkJc3luYwoJCWk9MAoJCXdoaWxlIFsgJGkgLWx0ICRwIF0KCQlkbwoJCQllY2hvICJuZXRw
ZXJmIC1jIC1DIC12IDEgLXQgVENQX1NUUkVBTSBcCgkJCQktSTk5LDUgLWwgJFRJTUUgLUggJHNl
cnZlciAtLSAtbSAkc2l6ZSBcCgkJCQktTSAkc2l6ZSAtRCAmIgoJCQlpPSRpKzEKCQlkb25lCgkJ
d2FpdAoJKSA+PiAkcmVzL3RjcF9kLiRwIDI+JjEKCWRvbmUKCglmb3IgcCBpbiAkUAoJZG8KCSgK
CQllY2hvICJFMTAwMCBSdW5uaW5nICRwIFVEUChzKSBUZXN0IHNpemU6JHNpemUiCgkJc3luYwoJ
CWk9MAoJCXdoaWxlIFsgJGkgLWx0ICRwIF0KCQlkbwoJCQllY2hvICJuZXRwZXJmIC1jIC1DIC12
IDEgLXQgVURQX1NUUkVBTSBcCgkJCQktSTk5LDUgLWwgJFRJTUUgLUggJHNlcnZlciAtLSAtbSAk
c2l6ZSBcCgkJCQktTSAkc2l6ZSAmIgoJCQlpPSRpKzEKCQlkb25lCgkJd2FpdAoJKSA+PiAkcmVz
L3VkcC4kcCAyPiYxCglkb25lCmRvbmUKZWNobyAiRmluaXNoZWQgYXQgOiBgZGF0ZWAiID4+ICRy
ZXMvREFURQo=

--0__=EABBF860DF8EDEA88f9e8a93df938690918cEABBF860DF8EDEA8--

