From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH 14/16] net: dsa: Add new binding implementation
Date: Fri, 27 May 2016 14:29:04 -0700
Message-ID: <5748BC20.4010502@gmail.com>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
 <1464312050-23023-15-git-send-email-andrew@lunn.ch>
 <8737p3z15i.fsf@ketchup.mtl.sfl> <20160527205759.GB6027@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, John Crispin <john@phrozen.org>,
	Bryan.Whitehead@microchip.com
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33663 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915AbcE0V3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 17:29:07 -0400
Received: by mail-pa0-f66.google.com with SMTP id f8so13874599pag.0
        for <netdev@vger.kernel.org>; Fri, 27 May 2016 14:29:07 -0700 (PDT)
In-Reply-To: <20160527205759.GB6027@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2016 01:57 PM, Andrew Lunn wrote:
> On Fri, May 27, 2016 at 04:39:05PM -0400, Vivien Didelot wrote:
>>
>> Hi Andrew, Florian,
>>
>> Here again, I'd suggested an implicit namespace for functions taking a
>> dsa_switch_tree structure as first argument, i.e. dsa_tree_do_foo().
> 
> Using tree actually makes things worse, since tree is never used
> anywhere in the current code. It is always called dst. If you do this,
> you also need to replace every instance of dst with tree.
> 
> We mostly have a good convention
> 
> struct dsa_switch *ds;
> dsa_switch_tree *dst;
> 
> What is not quite consistent is
> 
> struct dsa_chip_data *cd
> 
> which should really be
> 
> struct dsa_chip_data *dcd
> 
> but we are consistent with using cd everywhere.
>  
>> Since we are likely to spend some time in net/dsa, it'd be great to
>> introduce the new bindings and an intuitive API at the same time ;-)
> 
> They are two separate things. And the binding will be set in stone,
> never to be changed again in incompatible ways, where as the API we
> can change as much as we like. We should be concentrate on the
> binding.

I completely agree, Andrew has been working long enough on this it needs
to be posted and merged, anything that becomes a clean up on top of that
can be done at any random time, by you, me, or any kernel janitor who
feels like it.

We need to set priorities here, and the highest priority is to get these
patches accepted to enable more people to utilize DSA, so once we have
more devices we can get to a longer term plan to get a better
abstraction model for the switch devices that are in the source tree.

Considering the fast pace nature of the net-next tree, I am sure that
any kind of cleanup on this code after the patches get merged would be
merged in a matter of weeks, but it does not strike me as being a
blocker here.

Thanks
-- 
Florian
