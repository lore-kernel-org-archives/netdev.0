From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: tcp_info struct
Date: Mon, 26 Feb 2007 15:41:10 -0300
Message-ID: <39e6f6c70702261041u59646f9q16ab2dbe360a9b75@mail.gmail.com>
References: <45E319FE.8090707@i4.informatik.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michael Faber" <faber@i4.informatik.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.224]:16235 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030420AbXBZSlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 13:41:42 -0500
Received: by wr-out-0506.google.com with SMTP id 58so1648010wri
        for <netdev@vger.kernel.org>; Mon, 26 Feb 2007 10:41:40 -0800 (PST)
In-Reply-To: <45E319FE.8090707@i4.informatik.rwth-aachen.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/26/07, Michael Faber <faber@i4.informatik.rwth-aachen.de> wrote:
> Hi,
>
> i want to use the tcp_info struct to keep track of some tcp related
> information. This works fine so far, however i'm wondering how to
> interpret some of the values delivered. I would expect values like cwnd
> and sst to be given out in packets regarding the source code. Can anyone
> give me some hints in interpreting the tcp_info values as this option is
> very poor documented and only documentation on how to fill the tcp_info
> struct can be found.

Rule #N: Use the current users as the documentation

Use rule #N, by looking at the iproute2 source code, more specifically
the ss source code 8)

- Arnaldo
