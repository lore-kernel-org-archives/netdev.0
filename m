From: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Subject: Re: iwlwifi worse than ever in current git.
Date: Tue, 10 Jan 2012 09:54:21 -0800
Message-ID: <1326218061.13074.383.camel@wwguy-huron>
References: <20120110184917.GA26973@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: emmanuel.grumbach@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2244 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756664Ab2AJS6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 13:58:08 -0500
In-Reply-To: <20120110184917.GA26973@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Emmanuel,

On Tue, 2012-01-10 at 13:49 -0500, Dave Jones wrote:
> For the last few releases, iwlwifi has been getting consistently worse
> wrt reliability for me.  The failure mode has varied, from the chip just
> locking up with no tx/rx of packets with nothing being logged, to
> microcode warnings, and spewing 'Tx aggregation enabled' messages over and over.
> 
> The merge post 3.2 has made these problems a lot worse.  Before, these
> lock-ups were happening once or twice a day. Now they happen several times an hour
> (and after the first one, they seem more frequent). When they happen,
> unloading and reloading the module is the only way for me to get working wireless again.
> They may happen more frequently when the laptop is not idle.
> 
> I did a bisect of the changes since 3.2, which pointed at 76bc10fcd128ad028cf77c62e179cd20dc2ffecf
> as being the culprit, but to be honest I'm not 100% convinced.
> 
> Because every step of the way during the bisect, I saw different failure modes,
> so when I marked something as 'good', it meant "doesn't lock up in the same way",
> even though it may be symptomatic of the same problem.
> 
> The specific chip I'm using is a 5300 in a Dell Adamo, connecting to
> an Apple airport extreme (current model) in N mode.
> 
ANy thought on this, patch 76bc10fcd128ad028cf77c62e179cd20dc2ffecf move
the tid_data to different layer, it shall not have any functional
changes.

Thanks
Wey
> 
