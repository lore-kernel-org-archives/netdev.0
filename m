From: Roland Dreier <rolandd@cisco.com>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 16:38:13 -0700
Message-ID: <52br1xdjtm.fsf@cisco.com>
References: <1128672413.13948.326.camel@localhost> <52br20lsei.fsf@cisco.com>
	<1128738350.13945.369.camel@localhost> <521x2tgrim.fsf@cisco.com>
	<1128986707.13945.424.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Matt Leininger <mlleinin@hpcn.ca.sandia.gov>
In-Reply-To: <1128986707.13945.424.camel@localhost> (Matt Leininger's
	message of "Mon, 10 Oct 2005 16:25:07 -0700")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Matt>   Pretty consistent.  Here are a few runs with 2.6.12-rc5
    Matt> with reboots in between each run.  I'm using netperf-2.3pl1.

That's interesting.  I'm guessing you're using mem-ful HCAs?

Given that your results are more stable than mine, if you're up for
it, you could install git, clone Linus's tree, and then do a git
bisect between 2.6.12-rc4 and 2.6.12-rc5 to narrow down the regression
to a single commit (if in fact that's possible).

 - R.
