From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] iproute2: show network device dependency tree
Date: Sun, 26 Feb 2017 15:46:10 +0100
Message-ID: <20170226144610.GB2071@nanopsycho.orion>
References: <20170225165900.10129-1-zaboj.campula@post.cz>
 <20170225173927.GA2479@nanopsycho>
 <1488054142.3856.15.camel@post.cz>
 <20170226075633.GA1788@nanopsycho>
 <1488117614.1903.2.camel@post.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com
To: Zaboj Campula <zaboj.campula@post.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33394 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752125AbdBZOqN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 09:46:13 -0500
Received: by mail-wm0-f68.google.com with SMTP id v77so9763668wmv.0
        for <netdev@vger.kernel.org>; Sun, 26 Feb 2017 06:46:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1488117614.1903.2.camel@post.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Feb 26, 2017 at 03:00:14PM CET, zaboj.campula@post.cz wrote:
>On Sun, 2017-02-26 at 08:56 +0100, Jiri Pirko wrote:
>> Sat, Feb 25, 2017 at 09:22:22PM CET, zaboj.campula@post.cz wrote:
>> > On Sat, 2017-02-25 at 18:39 +0100, Jiri Pirko wrote:
>> > > > Sat, Feb 25, 2017 at 05:59:00PM CET, zaboj.campula@post.cz
>> > > > wrote:
>> > > > Add the argument '-tree' to ip-link to show network devices
>> > > > dependency tree.
>> > > > 
>> > > > Example:
>> > > > 
>> > > > $ ip -tree link
>> > > > eth0
>> > > >    bond0
>> > > > eth1
>> > > >    bond0
>> > > > eth2
>> > > >    bond1
>> > > > eth3
>> > > >    bond1
>> > > 
>> > > 
>> > > Hmm, what is this good for? I'm probably missing something...
>> > 
>> > I consider this kind of output useful when troubleshooting a complex
>> > configuration with many interfaces. It may show relations among
>> > interfaces.
>> 
>> Did you see https://github.com/jbenc/plotnetcfg ?
>> 
>
>Thanks for the link. I haven't seen plotnetcfg and I like it.
>It is handy when the analyzed system has GUI.

You can also run it remotelly. Also I believe that you can catch the
state into some dump file and process it later on. Not 100% sure though.
Ccing Jiri Benc who is the original author of plotnetcfg.
