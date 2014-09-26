From: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH/RFC repost 7/8] ofproto: translate datapath
 select group action
Date: Fri, 26 Sep 2014 16:57:25 -0700
Message-ID: <20140926235725.GB20493@nicira.com>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-8-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1411005311-11752-8-git-send-email-simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Thu, Sep 18, 2014 at 10:55:10AM +0900, Simon Horman wrote:
> This patch is a prototype and has several limitations:
> 
> * It assumes that no actions follow a select group action
>   because the resulting packet after a select group action may
>   differ depending on the bucket used. It may be possible
>   to address this problem using recirculation. Or to not use
>   the datapath select group in such situations. In any case
>   this patch does not solve this problem or even prevent it
>   from occurring.

It seems like this limitation in particular is a pretty big one.  Do
you have a good plan in mind for how to resolve it?
