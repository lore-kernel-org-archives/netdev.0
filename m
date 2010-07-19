From: Richard Hartmann <richih.mailinglist@gmail.com>
Subject: Priority/queueing on vitrual interfaces -- do virtual interfaces have
	a queue?
Date: Tue, 20 Jul 2010 00:36:25 +0200
Message-ID: <AANLkTimxw2Kf2ztzrHLvvLYYIbQ0RwcqmfAdT9TidAQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	lartc@mailman.ds9a.nl
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I am using a HTB qdisc with one intermediate class and half a dozen
leaf classes. All leaf classes (other than the first) are allowed to
starve all classes below them (far from ideal, but a hard requirement).

Things work fine, but it seems that prio is more or less ignored.

I found one online source that claimed that due to the fact that
virtual interfaces don't have a buffer, their send queue is always
empty and thus prio would not do anything. Yet, I can hardly
believe that.

I would appreciate any input on this.

You can find my current config at [1]. Please, no discussions
about starving the lower classes. I know.


-- 
Richard

[1] http://paste.debian.net/80919/
