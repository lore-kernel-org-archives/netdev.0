From: Jesse Gross <jesse@nicira.com>
Subject: Re: RFC - VXLAN port range facility
Date: Fri, 31 May 2013 15:09:34 +0900
Message-ID: <CAEP_g=8MkoK3DLJNGCrQYj_X9hB9P9fjH9hrpBwqOE=0OKWGdg@mail.gmail.com>
References: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com>
 <20130530094141.7c125947@nehalam.linuxnetplumber.net> <OFD5BD589B.1842E46B-ON85257B7B.00610E03-85257B7B.0062F480@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:59998 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752094Ab3EaGJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 02:09:55 -0400
Received: by mail-ie0-f171.google.com with SMTP id s9so2967094iec.2
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 23:09:54 -0700 (PDT)
In-Reply-To: <OFD5BD589B.1842E46B-ON85257B7B.00610E03-85257B7B.0062F480@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 31, 2013 at 3:00 AM, David Stevens <dlstevens@us.ibm.com> wrote:
> But I don't think there's particular advantage in splitting it up 30,000
> ways when 10 ways would be both practical, for binding, and spread
> traffic to 10 flows potentially.

Most people that run large data centers think that 16 bits of entropy
is barely sufficient. The issue is not CPUs or link aggregation but
Clos fabrics built using ECMP.
