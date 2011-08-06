From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [RFC 4/4] [powerpc] Implement a p1010rdb clock source.
Date: Sat, 6 Aug 2011 11:52:45 -0500
Message-ID: <39414D86-7822-4B92-B005-351890A2A167@kernel.crashing.org>
References: <1312603504-30282-1-git-send-email-holt@sgi.com> <1312603504-30282-5-git-send-email-holt@sgi.com> <4E3D4875.30707@pengutronix.de>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Robin Holt <holt@sgi.com>, Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	socketcan-core@lists.berlios.de, Netdev <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org Development"
	<linuxppc-dev@lists.ozlabs.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37010 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752732Ab1HFQxK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 12:53:10 -0400
In-Reply-To: <4E3D4875.30707@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Aug 6, 2011, at 8:58 AM, Marc Kleine-Budde wrote:

> On 08/06/2011 06:05 AM, Robin Holt wrote:
>> flexcan driver needs the clk_get, clk_get_rate, etc functions
>> to work.  This patch provides the minimum functionality.
> 
> This patch has to go via the powerpc git tree. Added
> linuxppc-dev@lists.ozlabs.org on CC.
> 
>> Signed-off-by: Robin Holt <holt@sgi.com>
>> To: Marc Kleine-Budde <mkl@pengutronix.de>
>> To: Wolfgang Grandegger <wg@grandegger.com>
>> To: U Bhaskar-B22300 <B22300@freescale.com>
>> Cc: socketcan-core@lists.berlios.de
>> Cc: netdev@vger.kernel.org
>> ---
>> arch/powerpc/platforms/85xx/p1010rdb.c |   78 ++++++++++++++++++++++++++++++++
>> 1 files changed, 78 insertions(+), 0 deletions(-)

NAK.

This doesn't look right at all.  We should be doing something based on the device tree node that isn't board specific.

I believe Bhaskar has a version of flexcan support that he's been working on cleanup up for upstream.

- k