From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Wed, 23 Oct 2002 07:52:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB6B798.1523042A@us.ibm.com>
References: <200210231218.18733.roy@karlsbakk.net> <200210231306.18422.roy@karlsbakk.net> <200210231309.g9ND9Bp03373@Port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Roy Sigurd Karlsbakk <roy@karlsbakk.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vda@port.imtp.ilyichevsk.odessa.ua
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Denis Vlasenko wrote:

> I know zero about networking, but why 120 000 csum_partial_copy_generic
> and inly 20 000 nic interrupts? That may be abnormal.
> --
> vda

Because firstly, we pick up several packets per interrupt,
and additionally, the function is also called on the send side.

thanks,
Nivedita
