From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/10] Preparatory refactoring part 2.
Date: Mon, 01 Oct 2007 15:33:09 +0200
Message-ID: <4700F715.9000200@trash.net>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199773306-git-send-email-bugfood-ml@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32940 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbXJANdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:33:33 -0400
In-Reply-To: <11910199773306-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> The sfq_destroy() --> sfq_q_destroy() change looks pointless here,
> but it's cleaner to split now and add code to sfq_q_destroy() in a
> later patch.
> 
> +static void sfq_destroy(struct Qdisc *sch)
> +{
> +	struct sfq_sched_data *q = qdisc_priv(sch);
> +	sfq_q_destroy(q);
> +}


It does look pointless, after applying all patches sfq_destroy still
remains a simply wrapper around sfq_q_destroy.
