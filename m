From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 2.6.10 0/22] Add hardware assist for IPSEC crypto
Date: Fri, 21 Jan 2005 14:35:02 -0800
Message-ID: <20050121143502.69c160cc.davem@davemloft.net>
References: <20041230035000.01@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <20041230035000.01@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Dec 2004 03:48:34 -0500
David Dillow <dave@thedillows.org> wrote:

> Bandwidth tests
> 
> Config (sender -> receiver)		Bandwidth	ori CPU	  tank CPU
> No IPSEC (tank->ori)			11494 KB/s	11.9%	  18.7%
> No IPSEC (ori->tank)			11492 KB/s	9.5%	  34.3%
> 
> AH/SHA1 (sw) (tank->ori)		11303 KB/s	29.2%	  79.3%
> AH/SHA1 (sw) (ori->tank)		11302 KB/s	28.6%	  91.1%
> ESP/3DES,SHA1 (sw) (tank->ori)		2130 KB/s	29.6%	  100%
> ESP/3DES,SHA1 (sw) (ori->tank)		2263 KB/s	29.3%	  99.7%
> ESP-AH/3DES,SHA1-SHA1 (sw) (tank->ori)	1906 KB/s	29.1%	  100%
> ESP-AH/3DES,SHA1-SHA1 (sw) (ori->tank)	2051 KB/s	29.3%	  99.7%

It's a shame we don't have an assembler optimized 3DES at least for
x86 in the crypto library of the kernel, even if just for tests such
as this.

I'll start reviewing your patches right now.
