From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: [Bugme-new] [Bug 1148] New: when using ipsec with DSL
 connections communication will hang if mtu is 1500(the default value)
Date: Tue, 26 Aug 2003 23:04:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030826230455.70059a69.davem@redhat.com>
References: <20030826003949.78ea3d07.akpm@osdl.org>
	<20709.1061931582@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com, uwe.schmeling@t-online.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
In-Reply-To: <20709.1061931582@marajade.sandelman.ottawa.on.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 26 Aug 2003 16:59:42 -0400
Michael Richardson <mcr@sandelman.ottawa.on.ca> wrote:

>   This sure sounds like a classif pmtud blackhole problem.

Regardless of his configuration, we don't propagate PMTU's
over tunneled IPSEC connections properly at all.
