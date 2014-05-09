From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc/netem: fix loss state display and p14
 parsing
Date: Fri, 9 May 2014 12:07:49 -0700
Message-ID: <20140509120749.0150c757@nehalam.linuxnetplumber.net>
References: <13144.1399600940@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netem@lists.linux-foundation.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:58410 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756903AbaEITHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 15:07:52 -0400
Received: by mail-pd0-f172.google.com with SMTP id g10so4104703pdj.3
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 12:07:52 -0700 (PDT)
In-Reply-To: <13144.1399600940@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 May 2014 19:02:20 -0700
Jay Vosburgh <jay.vosburgh@canonical.com> wrote:

> 
> 	The display of the entire netem loss state is shown as if it
> were gemodel state, as the loss state information is assigned to the
> wrong pointer.  Correct this by assigning the loss state to the correct
> pointer.
> 
> 	Additionally, attempting to set netem loss state will result in
> random values in the p14 state probability because the option value
> passed to the kernel by tc netem is not parsed or initialized.  Fix this
> by supplying a default value of 0 for p14 and parsing the p14 value if
> one is supplied.
> 
> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
> 
> ---
>  tc/q_netem.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)

Applied
