From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2] jsonw: Fix indentation of ending "}"
Date: Thu, 21 Jul 2016 11:38:12 +0200
Message-ID: <20160721093812.GC2171@nanopsycho.orion>
References: <1468828277-19308-1-git-send-email-jiri@resnulli.us>
 <20160720121924.689f15f5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38008 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbcGUJiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 05:38:15 -0400
Received: by mail-wm0-f44.google.com with SMTP id o80so17880680wme.1
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 02:38:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160720121924.689f15f5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jul 20, 2016 at 09:19:24PM CEST, stephen@networkplumber.org wrote:
>On Mon, 18 Jul 2016 09:51:17 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Fix indentation of the very last "}" which is currently indented,
>> leaving the last 2 "}" like this:
>> \t}
>> \t}
>> EOF
>> 
>> So fix it to be:
>> \t}
>> }
>> EOF
>> 
>> Fixes fcc16c2287 ("provide common json output formatter")
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>This no longer applies, put in change to json_writer for bridge formatting.
>Is it still needed?

Looks like this is fixed now in master. Please drop this. Thanks.
