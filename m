From: "Andrew Hall" <andrew.a.hall@gmail.com>
Subject: RE: Accessing certain web sites broken from 2.6.19+
Date: Fri, 11 May 2007 15:16:09 +1000
Message-ID: <4643fc1e.095ef753.14ef.ffffb9a8@mx.google.com>
References: <4643efc2.7cb1b0b0.2a08.4658@mx.google.com> <7e63f56c0705102138q5a623fadm520473df49e49963@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Robert Iakobashvili'" <coroberti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:18020 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbXEKFQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 01:16:15 -0400
Received: by py-out-1112.google.com with SMTP id a29so687528pyi
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 22:16:15 -0700 (PDT)
In-Reply-To: <7e63f56c0705102138q5a623fadm520473df49e49963@mail.gmail.com>
Content-Language: en-au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Robert Iakobashvili [mailto:coroberti@gmail.com]
> Sent: Friday, 11 May 2007 2:38 PM
> To: Andrew Hall
> Cc: netdev@vger.kernel.org
> Subject: Re: Accessing certain web sites broken from 2.6.19+
> 
> On 5/11/07, Andrew Hall <andrew.a.hall@gmail.com> wrote:
> > When accessing certain web sites when using any kernel above 2.6.19,
> TCP
> > seems to break. Connection to the site is established but never
> completes.
> > One particular site is www.dcita.gov.au. Is there a known issue
> pertaining
> > to this? Using any kernel below 2.6.19 (for example: 2.6.12 or
> 2.6.15) works
> > fine.
> 
> Including 2.6.21?
> 
> Which browser/s have you tried?
> 
> --
> Sincerely,
> Robert Iakobashvili,
> coroberti %x40 gmail %x2e com
> ...........................................................
> http://curl-loader.sourceforge.net
> A web testing and traffic generation tool.

I have not yet tried 2.6.21.. only tried to 2.6.20.9. The issue isn't
browser dependent ,as a wget directly from the OS will also fail during the
connection. Interestingly requests made from hosts behind the 2.6.20 gateway
that make the same request work fine, it seems it's only requests made from
the localhost itself.

