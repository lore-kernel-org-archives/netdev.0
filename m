From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [PATCH SECURITY]: orinoco: Information leakage due to
 incorrect	padding
Date: Fri, 07 Oct 2005 09:39:43 -0400
Message-ID: <1128692383.13065.23.camel@dv>
References: <1128475990.11708.21.camel@dv> <20051007032537.GB3936@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: orinoco-devel <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Meder Kydyraliev <meder-ljIgrh4ImVw@public.gmane.org>
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Jouni Malinen <jkmaline-kf+aQKke1yb1KXRcyAk9cg@public.gmane.org>
In-Reply-To: <20051007032537.GB3936-mgr6C1c9aYeHXe+LvDLADg@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Hi, Jouni!

On Thu, 2005-10-06 at 20:25 -0700, Jouni Malinen wrote:
> On Tue, Oct 04, 2005 at 09:33:10PM -0400, Pavel Roskin wrote:
> 
> > orinoco: Information leakage due to incorrect padding
> > 
> > The orinoco driver can send uninitialized data exposing random pieces of
> > the system memory.  This happens because data is not padded with zeroes
> > when its length needs to be increased.
> 
> Issue itself looks valid in the current implementation, but a better fix
> would be to just remove the padding.

Thank you!  With you and Jean saying that, I'm pretty much reassured
now :-)

I'll do it in Orinoco CVS soon and then I'll submit the patch.

The patch I posted is actually a simplified version of the patch
actually applied to the orinoco CVS, to make it as safe as possible for
Linux 2.6.14 inclusion.

-- 
Regards,
Pavel Roskin



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
