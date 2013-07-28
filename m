From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.11] genetlink: release cb_lock before requesting
 additional module
Date: Sat, 27 Jul 2013 22:20:03 -0700 (PDT)
Message-ID: <20130727.222003.1753039618642833143.davem@davemloft.net>
References: <20130725105116.043a6b9c@corrin.poochiereds.net>
	<20130726090010.GA1756@redhat.com>
	<CALnjE+rcMoFkDPSQbD7VKvv2rYzKKEYcARtBH5y_A+ngrLbAzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com, netdev@vger.kernel.org, tgraf@suug.ch,
	shemminger@vyatta.com, rjones@redhat.com, marcel@holtmann.org,
	jlayton@redhat.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730Ab3G1FUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 01:20:05 -0400
In-Reply-To: <CALnjE+rcMoFkDPSQbD7VKvv2rYzKKEYcARtBH5y_A+ngrLbAzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Fri, 26 Jul 2013 10:08:25 -0700

> On Fri, Jul 26, 2013 at 2:00 AM, Stanislaw Gruszka <sgruszka@redhat.com> wrote:
>> Requesting external module with cb_lock taken can result in
>> the deadlock like showed below:
 ...
>> Problem start to happen after adding net-pf-16-proto-16-family-nl80211
>> alias name to cfg80211 module by below commit (though that commit
>> itself is perfectly fine):
>>
>> commit fb4e156886ce6e8309e912d8b370d192330d19d3
>> Author: Marcel Holtmann <marcel@holtmann.org>
>> Date:   Sun Apr 28 16:22:06 2013 -0700
>>
>>     nl80211: Add generic netlink module alias for cfg80211/nl80211
>>
>> Reported-and-tested-by: Jeff Layton <jlayton@redhat.com>
>> Reported-by: Richard W.M. Jones <rjones@redhat.com>
>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
 ...
> This is genl issue and it was introduced by commit def3117493eafd
> (genl: Allow concurrent genl callbacks.).
> 
> Reviewed-by: Pravin B Shelar <pshelar@nicira.com>

Applied and queued up for -stable, thanks.
