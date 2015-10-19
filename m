From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2] ss: return -1 if an unrecognized option was
 given
Date: Sun, 18 Oct 2015 21:45:45 -0700
Message-ID: <20151018214545.74983d8c@xeon-e3>
References: <1444935676-10068-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:16517 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751209AbbJSEpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 00:45:42 -0400
In-Reply-To: <1444935676-10068-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Oct 2015 21:01:16 +0200
Phil Sutter <phil@nwl.cc> wrote:

> When getopt_long encounters an option which has not been registered, it
> returns '?'. React upon that and call usage() instead of help() so ss
> returns with a non-zero exit status.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied
