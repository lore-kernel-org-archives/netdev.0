From: "Hubert Sokolowski" <h.sokolowski@wit.edu.pl>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Thu, 11 Dec 2014 17:06:22 -0000
Message-ID: <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>
    <54894850.5000603@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, "Jamal Hadi Salim" <hadi@mojatatu.com>
To: "Roopa Prabhu" <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dervish.wsisiz.edu.pl ([213.135.44.54]:51781 "EHLO
	dervish.wsisiz.edu.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932950AbaLKRGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 12:06:25 -0500
In-Reply-To: <54894850.5000603@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


My apologies for sending again, I forgot to include a sample output you asked.

> Also, if i hear your concern correctly, for bridge ports that implement
> ndo_fdb_dump, with commit 5e6d243587990a588143b9da3974833649595587, we
> will get two entries for each 'self' entry above.
> Can you also paste sample output for that ?.
>

[root@silpixa00378825 ~]# bridge fdb show brport mac0
33:33:00:00:00:01 self permanent
33:33:00:00:00:01 self permanent

Regards,
Hubert
