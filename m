From: Patrick McHardy <kaber@trash.net>
Subject: Re: System freeze on reboot - general protection fault
Date: Mon, 17 Aug 2009 16:03:16 +0200
Message-ID: <4A896324.3040104@trash.net>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>	 <alpine.DEB.1.10.0908111032110.30494@gentwo.org>	 <c4e36d110908110752x253e30epb00cc71f4683052b@mail.gmail.com>	 <alpine.DEB.1.10.0908111056550.30494@gentwo.org>	 <c4e36d110908110832y21fba830ub8804613df571228@mail.gmail.com>	 <20090811154853.GF2763@sgi.com>	 <c4e36d110908111410y29b922ceod6871fda2514f6e6@mail.gmail.com>	 <c4e36d110908121516u504809e9y537e9babfa95df1d@mail.gmail.com>	 <alpine.DEB.1.10.0908121820410.3257@gentwo.org>	 <c4e36d110908131009l78b29bffvb4d41b90f9b83288@mail.gmail.com> <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com> <4A87CE60.4020506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Christoph Lameter <cl@linux-foundation.org>,
	Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754011AbZHQODT@vger.kernel.org>
In-Reply-To: <4A87CE60.4020506@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Zdenek Kabelac a =E9crit :
>>  [<ffffffffa02c502f>] nf_conntrack_ftp_fini+0x2f/0x70 [nf_conntrack_=
ftp]
>>  [<ffffffff8027bcc5>] sys_delete_module+0x1a5/0x270
>>  [<ffffffff8020d329>] ? retint_swapgs+0xe/0x13
>>  [<ffffffff80271bf2>] ? trace_hardirqs_on_caller+0x162/0x1b0
>>  [<ffffffff80292121>] ? audit_syscall_entry+0x191/0x1c0
>>  [<ffffffff80526dae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>>  [<ffffffff8020c84b>] system_call_fastpath+0x16/0x1b
>> Code: c6 00 00 0f 82 66 ff ff ff 49 8b 9e d8 05 00 00 48 85 db 75 16
>> e9 8e 00 00 00 0f 1f 44 00 00 48 85 c0 0f 84 80 00 00 00 48 89 c3 <0=
f>
>> b6 4b 37 48 8b 03 48 8d 14 cd 00 00 00 00 0f 18 08 48 29 ca
>> RIP  [<ffffffffa02b2c2c>] nf_conntrack_helper_unregister+0x16c/0x320
>> [nf_conntrack]
>>  RSP <ffff88013982fe68>
>> CR2: 0000000000000038
>> ---[ end trace bc3a0ede3d0084db ]---
>>
> I am currently traveling and wont be able to help you before next wee=
k.
>=20
> I added netdev, Patrick, and netfilter-devel in CC so that more eyes =
can take a look.

Thanks for the report, I'll have a look at this. Zdenek, please
send me the nf_conntrack.ko file used in the above oops. Thanks.
