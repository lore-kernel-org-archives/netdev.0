From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Fri, 30 Jan 2009 18:52:24 -0800
Message-ID: <20090130185224.214b3a59@extreme>
References: <20090130112125.GA9908@ioremap.net>
	<20090130125337.GA7155@gondor.apana.org.au>
	<20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com>
	<20090130215008.GB12210@ioremap.net> <49837F7E.90306@cosmosbay.com>
	<20090130225113.GA13977@ioremap.net>
Reply-To: Fedora/Linux Management Tools <et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Return-path: <et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <20090130225113.GA13977-i6C2adt8DTjR7s880joybQ@public.gmane.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/et-mgmt-tools>,
	<mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/et-mgmt-tools>
List-Post: <mailto:et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Help: <mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/et-mgmt-tools>,
	<mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=subscribe>
Sender: et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Errors-To: et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: netdev.vger.kernel.org

My working hypothesis is:
  1. Something about Evgeniy's patch makes IPV6 (actually IPV4 in IPV6) be
     preferred over plain IPV4.
  2. Vino server (VNC) doesn't think ::ffff::127.0.0.1 is really the localhost
  3. protocol gets screwed up after that.

It is probably reproducible with other services that support IPV6.
