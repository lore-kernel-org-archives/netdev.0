From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH v2 net-next 2/7] xen-netback: retire guest rx
 side prefix GSO feature
Date: Tue, 4 Oct 2016 11:14:33 +0100
Message-ID: <a5153c34-f60c-6893-f2b8-8647ad00c9a6@citrix.com>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
 <1475573358-32414-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
        <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:46440 "EHLO
        SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753163AbcJDKOl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 06:14:41 -0400
In-Reply-To: <1475573358-32414-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/16 10:29, Paul Durrant wrote:
> As far as I am aware only very old Windows network frontends make use of
> this style of passing GSO packets from backend to frontend. These
> frontends can easily be replaced by the freely available Xen Project
> Windows PV network frontend, which uses the 'default' mechanism for
> passing GSO packets, which is also used by all Linux frontends.
> 
> NOTE: Removal of this feature will not cause breakage in old Windows
>       frontends. They simply will no longer receive GSO packets - the
>       packets instead being fragmented in the backend.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
