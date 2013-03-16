From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] connector: Added coredumping event to the process connector
Date: Sat, 16 Mar 2013 18:03:48 +0100
Message-ID: <20130316170348.GD24041@order.stressinduktion.org>
References: <1363431050-24135-1-git-send-email-jderehag@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Evgeniy Polyakov <zbr@ioremap.net>, netdev@vger.kernel.org
To: Jesper Derehag <jderehag@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39177 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861Ab3CPRDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 13:03:49 -0400
Content-Disposition: inline
In-Reply-To: <1363431050-24135-1-git-send-email-jderehag@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 16, 2013 at 11:50:50AM +0100, Jesper Derehag wrote:
> +	ev->event_data.exit.exit_code = task->exit_code;
> +	ev->event_data.exit.exit_signal = task->exit_signal;

Do these already contain meaningful values?
