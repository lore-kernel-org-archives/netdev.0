From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] net: core: move core networking work to power
 efficient workqueue
Date: Thu, 30 Jan 2014 16:55:01 -0800
Message-ID: <1391129701.2422.75.camel@joe-AO722>
References: <1391128402-10725-1-git-send-email-zoran.markovic@linaro.org>
	 <52EAF2E5.8090403@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Zoran Markovic <zoran.markovic@linaro.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52EAF2E5.8090403@meshcoding.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-01-31 at 01:48 +0100, Antonio Quartulli wrote:
> On 31/01/14 01:33, Zoran Markovic wrote:
> > From: Shaibal Dutta <shaibal.dutta@broadcom.com>
> 
> [...]
> 
> > -		schedule_delayed_work(&linkwatch_work, delay);
> > +		queue_delayed_work(system_power_efficient_wq,
> > +			&linkwatch_work, delay);
> 
> before talking about technical details, here and in other spots of this
> patch the alignment is wrong. I think checkpatch should have said
> something about it. The first parameter on the new line should be
> aligned up to the column after the opening parenthesis.

Using "scripts/checkpatch.pl --strict" would emit an
alignment message, otherwise not.
