From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [PATH] IPv6 IPsec support
Date: Thu, 6 Mar 2003 09:32:19 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030306093219.1a702868.kazunori@miyazawa.org>
References: <20030305233025.784feb00.kazunori@miyazawa.org>
	<20030305.152530.70806720.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030305.152530.70806720.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello David,

On Wed, 05 Mar 2003 15:25:30 -0800 (PST)
"David S. Miller" <davem@redhat.com> wrote:

>    From: Kazunori Miyazawa <kazunori@miyazawa.org>
>    Date: Wed, 5 Mar 2003 23:30:25 +0900
> 
> Hello Miyazawa-san,
> 
>    I submit the patch to let the kernel support ipv6 ipsec again.
>    It is able to comple ipv6 as module.
> 
> As promised I applied the patch.  I will push it to Linus later
> this evening, or tomorrow.
> 
> In this initial checkin I made only 2 minor fixes, they
> are attached below:
> 

Thank you very much.

My patch is the first step.
 I think there are these TODOs around IPv6 IPsec as far as I remember.

- Extension Header Processing on inbound:
  As a result of IPv6 IPsec support, Extension Header processing is devided
  into ipv6_parse_exthdrs and ipproto->handler. I think it is better to merge
  other Extension Header handling into ipproto->handler.

- Fragmentation support on outbound:
  We should change ipv6_build_xmit like ip_append_data style to support
  fragmentation with IPsec.

- Removing duplicate codes, clean up and improveing performance.

- Considering relation of IPv6 IPsec and Mobile IPv6. This is future stuff.

Best regards,

--Kazunori Miyazawa (Yokogawa Electric Corporation)
