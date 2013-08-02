From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: PROBLEM: 3.11.0-rc2+ lost of connectivity
Date: Fri, 2 Aug 2013 02:47:50 +0000 (UTC)
Message-ID: <ktf6km$rsu$1@ger.gmane.org>
References: <CAOSRKdTOcYOZ4fD5gXe_57dA028rGmR30T32FQ6MeruAq2p04g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 01 Aug 2013 at 14:34 GMT, Sebastiano Spicuglia <spicuglia.sebastiano@gmail.com> wrote:
>
> The machine suddenly stops to be connected to the network.
> Running "ifdown eth0" "ifup eth0" the network starts to work
> again for few minutes and then the failure happens again.
> It is not even possible to ping the machine.
> /var/log/messages does not report anything wrong.
>
> I instrumented the kernel with SystemTap to see what happens when the
> machine is in the failure state.
>
> the function ip_rcv is invoked.
> the function ip_rcv_finish is invoked.
> the function ip_local_deliver is invoked
> the function ip_local_deliver_finish is invoked
> the function tcp_v4_rcv is NOT invoked
>
> When the network works the function tcp_v4_rcv is invoked.
>

Please turn off your firewall and run dropwatch to see where the
packets are dropped.
