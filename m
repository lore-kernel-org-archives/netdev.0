From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH 2/2] ipv4: make do_ip_setsockopt for IP_MULTICAST_IF support
 ip_mreq struct
Date: Thu, 17 Sep 2009 17:16:30 +0800
Message-ID: <4AB1FE6E.9000201@cn.fujitsu.com>
References: <1253164811-15820-1-git-send-email-dfeng@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, pekkas@netcore.fi, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Marc Milgram <mmilgram@redhat.com>
To: Xiaotian Feng <dfeng@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757121AbZIQJMK@vger.kernel.org>
In-Reply-To: <1253164811-15820-1-git-send-email-dfeng@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Xiaotian Feng wrote, at 09/17/2009 01:20 PM:
> ip_mreq and ip_mreqn is almost the same, and do_ip_setsockopt for IP_MULTICAST_IF
> part supported ip_mreqn struct. This patch adds support for ip_mreq struct.
> 

It's not meaning to support the ip_mreq struct, the imr_multiaddr member
never be used by the IP_MULTICAST_IF.

In addition, using the option normally like this: 
  struct in_addr interface_addr;
  setsockopt (socket, IPPROTO_IP, IP_MULTICAST_IF, &interface_addr, sizeof(interface_addr));
 
Do your patch suggest using the option like this?
  struct ip_mreq  mreq;
  setsockopt (socket, IPPROTO_IP, IP_MULTICAST_IF, &mreq, sizeof(mreq));
 

Best Regards
-----
Shan Wei
