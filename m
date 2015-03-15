From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 0/5] switchdev: add swdev ops
Date: Sun, 15 Mar 2015 10:56:34 -0700
Message-ID: <CAE4R7bCfzhmWznFQ_JsUfidCKbuT-rppjXRqpgOcd7uqw1h5FQ@mail.gmail.com>
References: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
	<20150315170355.GJ2043@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:36113 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbbCOR4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 13:56:34 -0400
Received: by qgg60 with SMTP id 60so23753890qgg.3
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 10:56:34 -0700 (PDT)
In-Reply-To: <20150315170355.GJ2043@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 10:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Sun, Mar 15, 2015 at 07:15:02AM CET, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>Per discussions at netconf, move switchdev ndo ops to a new swdev_ops to
>>keep ndo namespace clean and maintain switchdev-related ops into one place.
>>
>>There are no functional changes here; just shuffling ops around for better
>>organization.
>
> Hmm, I'm not sure this is the right approach. I think we do not need
> only switchdev ops to be pushed out. There are many more ndos that could
> be pushed out as well. What I'm thinking about is some more generic ndo
> struct partitioning. Have to think about the actual implementation some more.

I couldn't see a way to make a more generic ndo struct without casting
args to void * and back, or using a big overlay union.  I may be
missing your idea; interested in what you come up with.

In the meantime, can we go with this simple partitioning?

-scott
