From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH] net/dccp: Allow default/fallback service code
Date: Fri, 22 Sep 2006 15:37:57 +1200
Message-ID: <5640c7e00609212037y254b72day7553c40a14692a51@mail.gmail.com>
References: <200609111922.12855@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org,
	"Arnaldo Carvalho de Melo" <acme@mandriva.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.131]:12418 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S932252AbWIVDh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 23:37:59 -0400
Received: by nf-out-f131.google.com with SMTP id k65so10536nfa
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 20:37:58 -0700 (PDT)
To: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>
In-Reply-To: <200609111922.12855@strip-the-willow>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gerrit,

Not sure what happened here but I can't apply this with git-apply. Can
you check and resubmit. Looks great patch though and would love to
test! This would mean DCCP is easier to port to which must be good.

Just a quick note - you didn't updated last changed date in
Documentation/networking/dccp.txt. I think rather than updating you
can remove as people can find dates by looking at git history.

Ian

On 9/12/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Allow default/fallback service code.
>
> This has been discussed on dccp@vger and removes the necessity for
> applications to supply service codes in each and every case.
>
> If an application does not want to provide a service code, that's
> fine, it will be given 0. Otherwise, service codes can be set
> via socket options as before.
>
> This patch has been tested using various client/server configurations
> (including listening on multiple service codes) and patches against
> Torvalds' tree.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> --
>  Documentation/networking/dccp.txt |    7 +++++--
>  include/linux/dccp.h              |    6 +-----
>  net/dccp/ipv4.c                   |    3 ---
>  net/dccp/proto.c                  |   11 +----------
>  4 files changed, 7 insertions(+), 20 deletions(-)
>
>
> diff --git a/Documentation/networking/dccp.txt b/Documentation/networking/dccp.txt
> index c45daab..2f479af 100644
> --- a/Documentation/networking/dccp.txt
> +++ b/Documentation/networking/dccp.txt
> @@ -42,8 +42,11 @@ Socket options
>  DCCP_SOCKOPT_PACKET_SIZE is used for CCID3 to set default packet size for
>  calculations.
>
> -DCCP_SOCKOPT_SERVICE sets the service. This is compulsory as per the
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
