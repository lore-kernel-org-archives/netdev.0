From: syrius.ml@no-log.org
Subject: Re: IMQ / new Dummy device post.
Date: Wed, 21 Apr 2004 14:49:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wazza.87fzaxmr6x.fsf@message.id>
References: <wazza.87ad18jbdl.fsf@message.id>
	<1082427350.1034.70.camel@jzny.localdomain>
	<wazza.87fzayw1fy.fsf@message.id>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <wazza.87fzayw1fy.fsf@message.id> (syrius ml's message of "Wed,
 21 Apr 2004 03:43:13 +0200")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


skput:under: c88c93aa:98 put:14 dev:tun0kernel BUG at skbuff.c:113!
invalid operand: 0000                                              
CPU:    0            
EIP:    0010:[<c01bc2e9>]    Tainted: P 
EFLAGS: 00010286                        
eax: 00000028   ebx: c46afe60   ecx: 00000000   edx: c6a5e000
esi: c88c6780   edi: 00000001   ebp: c5573d78   esp: c5573d64
ds: 0018   es: 0018   ss: 0018                               
Process openvpn (pid: 940, stackpage=c5573000)
Stack: c022a180 c88c93aa 00000062 0000000e c5db4824 c5573da8 c88c93b2
c582e3a0 
       0000000e c88c93aa 42924e9d c58eccc0 c582ebe0 c582e3a0 c57dae00
       c582ebe0 
       c5f17f20 c5573dbc c01cd277 c5573dc4 c57dae00 c5573e60 c5573e28
       c890f104 
Call Trace:    [<c88c93aa>] [<c88c93b2>] [<c88c93aa>] [<c01cd277>]
[<c890f104>]
  [<c01bc5bd>] [<c01bc736>] [<c01f20fc>] [<c89123f9>] [<c89120fc>]
  [<c01c0a6a>]
  [<c01c0b6a>] [<c01c0d66>] [<c01c0e83>] [<c0119507>] [<c892cc35>]
  [<c01347a0>]
  [<c0134883>] [<c0106ff3>]                                                    
                           
Code: 0f 0b 71 00 0a 92 22 c0 89 ec 5d c3 8d 74 26 00 8d bc 27 00 
 <0>Kernel panic: Aiee, killing interrupt handler!                
In interrupt handler - not syncing                
                                  

I'm going to recompile the kernel with frame pointers, and i'll feed
the oops thru ksymoops.
First I have to narrow the problem so I can tell how to reproduce it,
and I'll give more informations.

-- 
