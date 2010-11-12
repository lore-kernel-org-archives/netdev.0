From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH] network: return errors if we know tcp_connect failed
Date: Fri, 12 Nov 2010 08:36:05 +0100
Message-ID: <4CDCEE65.3060105@trash.net>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com> <00c201cb81eb$84e18160$8ea48420$@com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: 'Eric Paris' <eparis@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org
To: Hua Zhong <hzhong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <00c201cb81eb$84e18160$8ea48420$@com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11.11.2010 22:58, Hua Zhong wrote:
>> Yes, I realize this is little different than if the
>> SYN was dropped in the first network device, but it is different
>> because we know what happened!  We know that connect() call failed
>> and that there isn't anything coming back.
> 
> I would argue that -j DROP should behave exactly as the packet is dropped in the network, while -j REJECT should signal the failure to the application as soon as possible (which it doesn't seem to do).

It sends an ICMP error or TCP reset. Interpretation is up to TCP.
