From: David Chappelle <chappedm@gmail.com>
Subject: Clarification on rtnetlink requests
Date: Wed, 19 Aug 2015 11:05:03 -0400
Message-ID: <CALj-AT+z+Mv5ZUZWDDxquaZKu3o5qstuarz-qLcx80CH_n7LGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:36765 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932109AbbHSPFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 11:05:04 -0400
Received: by ykfw73 with SMTP id w73so7672504ykf.3
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 08:05:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am a bit confused with respect to the structure of rtnetlink requests.
It seems that in some circumstances a request can look like:

    struct request
    {
        struct nlmsghdr header;
        struct rtgenmsg body;
    };

and in other cases it can look like:

    struct request
    {
        struct nlmsghdr header;
        struct ifinfomsg body;
    };

How do I know which one to use when sending RTM_GETLINK and
RTM_GETADDR requests? Furthermore, it also seems that 'struct rtattr'
can be specified at the end of the request as well. Is there any
documentation that describes this.
