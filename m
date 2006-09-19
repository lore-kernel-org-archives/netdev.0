From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 12/23] e1000: Maybe stop TX if not enough free descriptors
Date: Tue, 19 Sep 2006 16:45:06 -0400
Message-ID: <451056D2.4080909@pobox.com>
References: <20060919172623.4605.56860.stgit@gitlost.site>	<20060919172859.4605.60855.stgit@gitlost.site>	<45104719.9080708@pobox.com> <20060919125019.316d3790@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:28863 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1752069AbWISUpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 16:45:10 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060919125019.316d3790@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

looks OK except for the tasklet, which may starve if the lock is being 
held upon entry


