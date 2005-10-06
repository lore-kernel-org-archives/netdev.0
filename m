From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH SECURITY]: orinoco: Information leakage due to incorrect
Date: Thu, 6 Oct 2005 09:33:44 -0700
Message-ID: <20051006163344.GA19738@bougret.hpl.hp.com>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>,
	Orinoco Devel <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Content-Disposition: inline
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

Pavel Roskin wrote :
> 
> orinoco: Information leakage due to incorrect padding
> 
> The orinoco driver can send uninitialized data exposing random pieces of
> the system memory.  This happens because data is not padded with zeroes
> when its length needs to be increased.

	I believe the 802.11 doesn't specify and doesn't require
padding, therefore in theory, none of the 802.11 drivers need to do
padding.
	Padding is specific to the way the original Ethernet protocol
detect collisions over the wire, it require a minimum message length
due to the propagation and reflection time of the packet. Propagation
time is way faster over the air and we can't detect collisions anyway,
therefore it doesn't make sense to implement padding. It's just
unnecessary overhead.
	Now, I'm not 100% certain that all firmware and TCP/IP stack
would be happy with that, but it's worth a try at some point.

	Have fun...

	Jean



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
