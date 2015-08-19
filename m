From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 06/13] route: move lwtunnel state to dst_entry
Date: Tue, 18 Aug 2015 23:51:44 -0700
Message-ID: <55D42780.1040105@cumulusnetworks.com>
References: <cover.1439929916.git.jbenc@redhat.com> <c48cfe628ead51a567f596b93e40e464a3947628.1439929916.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33044 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555AbbHSGvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 02:51:46 -0400
Received: by pdrh1 with SMTP id h1so78162945pdr.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 23:51:45 -0700 (PDT)
In-Reply-To: <c48cfe628ead51a567f596b93e40e464a3947628.1439929916.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/15, 1:33 PM, Jiri Benc wrote:
> Currently, the lwtunnel state resides in per-protocol data. This is
> a problem if we encapsulate ipv6 traffic in an ipv4 tunnel (or vice versa).
> The xmit function of the tunnel does not know whether the packet has been
> routed to it by ipv4 or ipv6, yet it needs the lwtstate data. Moving the
> lwtstate data to dst_entry makes such inter-protocol tunneling possible.
>
> As a bonus, this brings a nice diffstat.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

great..! thanks for doing this. I was working on a similar patch.
