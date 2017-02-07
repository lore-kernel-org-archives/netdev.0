From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip route: Make name of protocol 0 consistent
Date: Tue, 7 Feb 2017 14:19:07 -0800
Message-ID: <20170207141907.175b89a7@xeon-e3>
References: <1486056126-23900-1-git-send-email-dsa@cumulusnetworks.com>
        <20170206140107.41569a73@xeon-e3>
        <5f55d6bb-ef2e-dbb0-c677-006964f1b7fe@cumulusnetworks.com>
        <20170207134035.58fa3fab@xeon-e3>
        <5d4b2d3f-300d-2486-c660-b4704c41cacd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34045 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932387AbdBGWTa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 17:19:30 -0500
Received: by mail-pf0-f169.google.com with SMTP id e4so36173238pfg.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 14:19:20 -0800 (PST)
In-Reply-To: <5d4b2d3f-300d-2486-c660-b4704c41cacd@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Feb 2017 14:51:45 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> On 2/7/17 2:40 PM, Stephen Hemminger wrote:
> >> Reading the file changes the string in rtnl_rtprot_tab for
> >> RTPROT_UNSPEC. Both string values -- "none" and "unspec" come from
> >> iproute2, so my point is that string is inconsistent within iproute2.  
> > 
> > Why not change the value in the table rtnl_rtprot_tab to be unspec this would
> > make the command consistent with the value in the header file.
> >   
> 
> I flipped a coin; it landed on config file.
> 
> "none" is the value that has shown up for 13+ years unless a custom
> protocol value is used triggering the 'unspec'. Seems to me a custom
> protocol value is a rare event suggesting conformity to "none" over
> "unspsec". I really don't care what the string is, but it should be
> consistent. If you want 'unspec' I'll change rtnl_rtprot_tab

Agree it was a coin toss, there were two values in iproute2, but the
kernel header file enum value should supersede.
