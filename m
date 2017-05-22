From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: add support for more MPLS labels
Date: Mon, 22 May 2017 11:04:27 -0700
Message-ID: <20170522110427.5da21124@xeon-e3>
References: <20170514012702.1083-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33961 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760727AbdEVSEf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:04:35 -0400
Received: by mail-pf0-f179.google.com with SMTP id 9so89415335pfj.1
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 11:04:35 -0700 (PDT)
In-Reply-To: <20170514012702.1083-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 13 May 2017 19:27:02 -0600
David Ahern <dsahern@gmail.com> wrote:

> Kernel now supports up to 30 labels but not defined as part of the uapi.
> iproute2 handles up to 8 labels but in a non-consistent way. Update ip
> to handle more labels, but in a more programmatic way.
> 
> For the MPLS address family, the data field in inet_prefix is used for
> labels.  Increase that field to 64 u32's -- 64 as nothing more than a
> convenient power of 2 number.
> 
> Update mpls_pton to take the length of the address field, convert that
> length to number of labels and add better error handling to the parsing
> of the user supplied string.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Looks good applied
