From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: [Bugme-new] [Bug 1148] New: when using ipsec with DSL
 connections communication will hang if mtu is 1500(the default value)
Date: Tue, 26 Aug 2003 02:22:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030826022252.054773d6.davem@redhat.com>
References: <20030826003949.78ea3d07.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, uwe.schmeling@t-online.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20030826003949.78ea3d07.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 26 Aug 2003 00:39:49 -0700
Andrew Morton <akpm@osdl.org> wrote:

> Begin forwarded message:

We don't do PMTU properly in tunneled mode, known problem
but fix won't happen any time soon as it's non-trivial
to cure this properly.
