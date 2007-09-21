From: jamal <hadi@cyberus.ca>
Subject: Re: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 07:59:06 -0400
Message-ID: <1190375946.4261.42.camel@localhost>
References: <1190359905.3551.28.camel@magi.nadr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: Emil Micek <emil.micek@tkrjasek.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:31990 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757876AbXIUL7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 07:59:11 -0400
Received: by an-out-0708.google.com with SMTP id d31so126283and
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 04:59:10 -0700 (PDT)
In-Reply-To: <1190359905.3551.28.camel@magi.nadr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-21-09 at 09:31 +0200, Emil Micek wrote:
> Hello list,
> 
> I'd like to change behaviour of e1000 module when transmiting short
> ethernet frames (shorter then 64 bytes) trough VLAN interface.
> 
> Current e1000 (according to our observations) first appends 4 bytes of
> VLAN tag and then pads the frame to 64 bytes with zeroes if necessary
> before transmiting it.

Which would make it a bug. AFAIK, the minimum VLAN tagged packet going
out is 68 bytes.

> I'd like to change it so it first pads the frame to 64 B and appends the
> VLAN tag afterwards, so the resulting VLAN frame would be 68 bytes
> minimum.

If you were able to figure this much out: What have you tried and what
do you still need help on? CCing some of the e1000 people(done) will
probably help you get this resolved faster.

cheers,
jamal

