From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.6-bk8] pcnet32: limit frames received during
 interrupt.
Date: Mon, 24 May 2004 11:24:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524112436.5ce66cc1@dell_ss3.pdx.osdl.net>
References: <200405222222.i4MMMJ512917@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <200405222222.i4MMMJ512917@DYN318364BLD.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 22 May 2004 15:22:19 -0700 (PDT)
Don Fry <brazilnut@us.ibm.com> wrote:

> The current code will allow an infinite number of frames to be received
> during one interrupt.  Tested ia32 and ppc64.

How about converting to support NAPI?
