From: Christopher Chan <cchan@outblaze.com>
Subject: Re: High number of concurrent connections causes 2.6.4 to go berserk
Date: Sat, 03 Apr 2004 00:37:21 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406D96C1.2000901@outblaze.com>
References: <406CBA60.50103@outblaze.com> <406CDDF5.4070500@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Yusuf Goolamabbas <yusufg@outblaze.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <406CDDF5.4070500@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>> The below values seem to workaround whatever problem the kernel has.
>>
>> tcp_max_syn_backlog = 2048
>> route.max_size = 1048576
>> route.gc_thresh = 65536

I take that back. Under peak hours, the kernel starts spewing its stuff 
onto serial console and network connectivity is lost.

What it spews is not human readable anymore.

eg:

3->g:asag6A &| <ilfart/tv4d_>rKEt d n SE1PERUELnet p-15 ( t bL:(D3laEED1 
f))sspv/ipi
3->g:asag6A &| <3leaititv4d_>r<3_npiti (q G__TRNtd  (c p. 
=msRN||E1(f_P33KNC: t/ne>c7116p-ug ala7gsK 2
a) sev4ipie<6)
: ssgsA &  M3>ediliocp/tsre3>nxieio(M E_PTRNE na(t (.c==sgNE| 
1DflPE3D)C) a/ietco1)63->g:asag6A  |
ai fer4/pved6>
cvcses  s MMS>Kd leonp.tceqc>KxtedonMSE1PERUELnet p(1c = g EL (D3laEED1 
f)asipt/op)
3->g:asag6A  |
ai fer4/pved6>
cvcoes  s MMS>Kd leonp.tceqc>KxtedonMSE1PERUELnet p-1c = g EL (D3laEED1 
f))sipt/op)
3->g:asag6A &| <ilfart/tv4d_>r<3_npiti eqSGG_ERatd  (ccpq vmER | E 
(G_D3EKNC:et n->57(1tpbu: fl37gsK12fa) sev4ipie<6)
c csesA &  M3>ediliocp/tseec>nxieio(M E_PTRNE nattp(.c==sgNE| 1DflPE3D) 
))asietco1)63->g:asag6A &| <ilfart/tv4d_>r<3_npiti eqSGG_ERatd  (c p. 
=msRN| E (G_D3EKNC: t/ne>c711tpbu: fl37gsK 2
a) sev4ipi
