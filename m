From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] zd1211rw: replace ZD_ASSERT with
 lockdep_assert_held()
Date: Thu, 11 Sep 2014 12:42:19 +0200
Message-ID: <1410432139.22863.10.camel@jlt4.sipsolutions.net>
References: <1410418407.1825.0.camel@jlt4.sipsolutions.net>
	 <1410430179-19944-1-git-send-email-sanjeev_sharma@mentor.com>
	 (sfid-20140911_121019_335368_163BEA7C) <1410430345.22863.0.camel@jlt4.sipsolutions.net>
	 <FDC088D3B5555644AE135ED28A7ABDE94DF5256D@EU-MBX-02.mgc.mentorg.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "dsd@gentoo.org" <dsd@gentoo.org>,
	"kune@deine-taler.de" <kune@deine-taler.de>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Sharma, Sanjeev" <Sanjeev_Sharma@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <FDC088D3B5555644AE135ED28A7ABDE94DF5256D@EU-MBX-02.mgc.mentorg.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-09-11 at 10:36 +0000, Sharma, Sanjeev wrote:

> > -	ZD_ASSERT(!spin_is_locked(&mac->lock));
> > +	lockdep_assert_held(&mac->lock);

> >Look closely at this again.
> 
> I didn't understand where I  put wrong logic  ?

Ok, that's fine. But please send a new patch only when you've understood
the logic.

johannes
