From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Sun, 6 Dec 2015 20:02:23 -0700
Message-ID: <5664F6BF.4060909@cumulusnetworks.com>
References: <CAKgT0Uc1bJRrzpLUdr3vOFkYZbcqP=J8wgOz1feF+u04aNBg1g@mail.gmail.com>
 <20151205.130313.1952213347830357234.davem@davemloft.net>
 <CAKgT0UfQCnz+oGfETZQs-nCP_QL_5qzngB+zC-e6ZN1-kV8C0Q@mail.gmail.com>
 <20151205.172742.1214683922564543621.davem@davemloft.net>
 <CAKgT0Udj2vNjqTO3HQKRoQajm-_Y6PdgQAu23Z8eQfnLRvsUiQ@mail.gmail.com>
 <CALx6S37rekP6c9umanJAFhzpBC=pvR6VBA6CvR13-n7rhFYT-Q@mail.gmail.com>
 <CAKgT0Uf4GGmeMKHZsr4ZPmRWxSDT4hEHpLr03SczQBJ8Ei6E4A@mail.gmail.com>
 <CALx6S36SdoYO6XJkwUQMtEO9OPm-Hb+qu9Kzt3Db7+ps9Wf4AQ@mail.gmail.com>
 <CAKgT0UdDrx8LWXzgGNfWZHY+XSMAmj7axK5Dn85+fJbghp+Cfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Linville <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34350 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754816AbbLGDCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 22:02:33 -0500
Received: by pacwq6 with SMTP id wq6so39854524pac.1
        for <netdev@vger.kernel.org>; Sun, 06 Dec 2015 19:02:32 -0800 (PST)
In-Reply-To: <CAKgT0UdDrx8LWXzgGNfWZHY+XSMAmj7axK5Dn85+fJbghp+Cfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/6/15 6:20 PM, Alexander Duyck wrote:
> That works for Linux to Linux, but what about the cases where you have
> a non-Linux endpoint on the other end such as something like a Cisco
> switch?

Why does is matter what kind of switch the NIC is connected to?
