From: Aldo Maggi <sentiniate@tiscali.it>
Subject: Re: two other cases Re: [Bug 11721] after upgrade to 2.6.27 i
 cannot navigate
Date: Wed, 22 Oct 2008 13:49:39 +0200
Message-ID: <20081022134939.64f2b6b4@topolino>
References: <Pine.LNX.4.64.0810211200170.7072@wrl-59.cs.helsinki.fi>
	<20081021201857.08faf0a7@topolino>
	<20081021184539.GA3320@ami.dom.local>
	<20081021.163207.157978465.davem@davemloft.net>
	<Pine.LNX.4.64.0810221244390.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/GTzZ.eRsHe+eGBoELqHOOey"
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org, olon@verizon.net
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jack.mail.tiscali.it ([213.205.33.53]:35790 "EHLO
	jack.mail.tiscali.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755931AbYJVLtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 07:49:52 -0400
In-Reply-To: <Pine.LNX.4.64.0810221244390.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/GTzZ.eRsHe+eGBoELqHOOey
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Il giorno Wed, 22 Oct 2008 13:00:01 +0300 (EEST)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> ha scritto:

[...]

>=20
> It would be nice for Aldo to check what the result will be with my
> second patch (only) using sack=3D1,ts=3D0,wscale=3D0. I guess it does but
> it's a bit unclear if nop's in front help or not (having the patch
> below should anyway help also in that case as the mss option gets
> moved before it anyway).

in order to avoid misunderstandings, i list herebelow my actions:

i've used on paperino the kernel 2.6.27.2 patched with ilpo's
21.10.2008 patch (see please comment 47 in
http://bugzilla.kernel.org/show_bug.cgi?id=3D11721, and NOT with the patch
contained in comment 58, right?)
i've modified the following files:
echo 0 > /proc/sys/net/ipv4/tcp_window_scaling
echo 0 > /proc/sys/net/ipv4/tcp_timestamps
echo 1 > /proc/sys/net/ipv4/tcp_sack

the results are that i CAN navigate (w3m kernel.org) and update my
system (apt-get update in debian).

should it be of any help to ilpo, i attach the usual tcpdump on the wan
eth of topolino (my home server/gw)

ciao!
aldo



[...]

--MP_/GTzZ.eRsHe+eGBoELqHOOey
Content-Type: application/octet-stream;
 name=2210-tcpdump_2-6-27-2-ilpo-2110-patch
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename=2210-tcpdump_2-6-27-2-ilpo-2110-patch

MTM6MzM6NDAuODkyNzUzIElQIDE5Mi4xNjguMjU0LjEuNDQ1MjkgPiAyMDQuMTUyLjE5MS41Ljgw
OiBTIDIyMjU5NDg5MjA6MjIyNTk0ODkyMCgwKSB3aW4gNTg0MCA8bm9wLG5vcCxzYWNrT0ssbXNz
IDE0NjA+CgkweDAwMDA6ICAwMGEwIGM1NDMgNWZlYiAwMDEwIDVhYzUgNjgxYyAwODAwIDQ1MDAg
IC4uLkNfLi4uWi5oLi4uRS4KCTB4MDAxMDogIDAwMzAgOGZhYyA0MDAwIDNmMDYgNjFkMyBjMGE4
IGZlMDEgY2M5OCAgLjAuLkAuPy5hLi4uLi4uLgoJMHgwMDIwOiAgYmYwNSBhZGYxIDAwNTAgODRh
ZCA0OGY4IDAwMDAgMDAwMCA3MDAyICAuLi4uLlAuLkguLi4uLnAuCgkweDAwMzA6ICAxNmQwIGE2
MWYgMDAwMCAwMTAxIDA0MDIgMDIwNCAwNWI0ICAgICAgIC4uLi4uLi4uLi4uLi4uCjEzOjMzOjQx
LjExMjk1NCBJUCAxOTIuMTY4LjI1NC4xLjQ0NTI5ID4gMjA0LjE1Mi4xOTEuNS44MDogLiBhY2sg
MjkyNzA0MjYzOCB3aW4gNTg0MAoJMHgwMDAwOiAgMDBhMCBjNTQzIDVmZWIgMDAxMCA1YWM1IDY4
MWMgMDgwMCA0NTAwICAuLi5DXy4uLlouaC4uLkUuCgkweDAwMTA6ICAwMDI4IDhmYWQgNDAwMCAz
ZjA2IDYxZGEgYzBhOCBmZTAxIGNjOTggIC4oLi5ALj8uYS4uLi4uLi4KCTB4MDAyMDogIGJmMDUg
YWRmMSAwMDUwIDg0YWQgNDhmOSBhZTc3IDIwNGUgNTAxMCAgLi4uLi5QLi5ILi53Lk5QLgoJMHgw
MDMwOiAgMTZkMCAwNDBlIDAwMDAgICAgICAgICAgICAgICAgICAgICAgICAgICAuLi4uLi4KMTM6
MzM6NDEuMTEzMjI3IElQIDE5Mi4xNjguMjU0LjEuNDQ1MjkgPiAyMDQuMTUyLjE5MS41LjgwOiBQ
IDA6MjQwKDI0MCkgYWNrIDEgd2luIDU4NDAKCTB4MDAwMDogIDAwYTAgYzU0MyA1ZmViIDAwMTAg
NWFjNSA2ODFjIDA4MDAgNDUwMCAgLi4uQ18uLi5aLmguLi5FLgoJMHgwMDEwOiAgMDExOCA4ZmFl
IDQwMDAgM2YwNiA2MGU5IGMwYTggZmUwMSBjYzk4ICAuLi4uQC4/LmAuLi4uLi4uCgkweDAwMjA6
ICBiZjA1IGFkZjEgMDA1MCA4NGFkIDQ4ZjkgYWU3NyAyMDRlIDUwMTggIC4uLi4uUC4uSC4udy5O
UC4KCTB4MDAzMDogIDE2ZDAgMDlmMCAwMDAwIDQ3NDUgNTQyMCAyZjIwIDQ4NTQgNTQ1MCAgLi4u
Li4uR0VULi8uSFRUUAoJMHgwMDQwOiAgMmYzMSAyZTMwIDBkMGEgNTU3MyA2NTcyIDJkNDEgNjc2
NSA2ZTc0ICAvMS4wLi5Vc2VyLUFnZW50CgkweDAwNTA6ICAzYTIwIDc3MzMgNmQyZiAzMDJlIDM1
MmUgMzIwZCAwYTQxIDYzNjMgIDoudzNtLzAuNS4yLi5BY2MK

--MP_/GTzZ.eRsHe+eGBoELqHOOey--
