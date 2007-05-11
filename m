From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Accessing certain web sites broken from 2.6.19+
Date: Fri, 11 May 2007 07:57:57 +0200
Message-ID: <7e63f56c0705102257r51e80d45s844cb14ebb6abb9b@mail.gmail.com>
References: <4643efc2.7cb1b0b0.2a08.4658@mx.google.com>
	 <7e63f56c0705102138q5a623fadm520473df49e49963@mail.gmail.com>
	 <4643fc1e.095ef753.14ef.ffffb9a8@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Andrew Hall" <andrew.a.hall@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:30098 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760317AbXEKF56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 01:57:58 -0400
Received: by wx-out-0506.google.com with SMTP id h31so771669wxd
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 22:57:58 -0700 (PDT)
In-Reply-To: <4643fc1e.095ef753.14ef.ffffb9a8@mx.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew,

On 5/11/07, Andrew Hall <andrew.a.hall@gmail.com> wrote:
> > > When accessing certain web sites when using any kernel above 2.6.19,
> > TCP seems to break. Connection to the site is established but never
> > completes.

Is it happening with a single connection, or when trying tens, hundreds,
thousands? Is it stalled?
Could you send a packet capture for such connection? Thank you.

> > > One particular site is www.dcita.gov.au. Is there a known issue
> > pertaining to this? Using any kernel below 2.6.19 (for example: 2.6.12 or
> > 2.6.15) works fine.

> I have not yet tried 2.6.21.. only tried to 2.6.20.9.

Please, try it with the most close configuration by using the
same config-file and running make oldconfig. There are some
issues fixed since that.

> The issue isn't browser dependent ,as a wget directly from the OS will also fail during the
> connection. Interestingly requests made from hosts behind the 2.6.20 gateway
> that make the same request work fine, it seems it's only requests made from
> the localhost itself.

To be in position to assist you, the people of the list may wish more
details, like:
1. wireshark or tcpdump capture of the broken/stalled sessions;
2. iptables ruleset dump and running modules list;
3. more knowledge about your kernel configuration (config file);
4. more details about your HW, particular networking and their drivers
(is not it a HW/card/driver specific issue?)

Y may wish to look at how other people are submitting issues/bugs with
more details.
-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...........................................................
http://curl-loader.sourceforge.net
A web testing and traffic generation tool.
