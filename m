From: Mark Glines <mark@glines.org>
Subject: Re: select(0, ..) is valid ?
Date: Tue, 15 May 2007 10:34:40 -0700
Message-ID: <20070515103440.696577b7@chirp>
References: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	Christoph Lameter <clameter@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from squawk.glines.org ([72.36.206.66]:51454 "EHLO squawk.glines.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761933AbXEORen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 13:34:43 -0400
In-Reply-To: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 May 2007 10:29:18 -0700
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> Hi,
> 
> Is select(0, ..) is a valid operation ?

select(0, ..) is rather commonly used as a portable sleep() with
microsecond granularity.  Disabling it will break lots of things.

Mark
