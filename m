From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Sat, 11 Jun 2011 13:06:25 -0700
Message-ID: <20110611200625.GB14582@kroah.com>
References: <1307748870-12950-1-git-send-email-marius@kotsbak.com>
 <20110610235557.GA23443@kroah.com>
 <4DF2B5E4.8070303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, "Marius B. Kotsbak" <marius@kotsbak.com>
To: Marius Kotsbak <marius.kotsbak@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:44139 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751715Ab1FKUOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 16:14:35 -0400
Content-Disposition: inline
In-Reply-To: <4DF2B5E4.8070303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 11, 2011 at 02:25:08AM +0200, Marius Kotsbak wrote:
> On 11. juni 2011 01:55, Greg KH wrote:
> > On Sat, Jun 11, 2011 at 01:34:30AM +0200, Marius B. Kotsbak wrote:
> >> Introducing driver for the network port of Samsung Kalmia based USB LTE modems.
> >> It has also an ACM interface that previous patches associates with the "option"
> >> module. To access those interfaces, the modem must first be switched from modem
> >> mode using a tool like usb_modeswitch.
> > Do we need to blacklist this device from the option driver?
> 
> It is already done, in commits:
> 
> 80f9df3e0093ad9f1eeefd2ff7fd27daaa518d25
> 15b2f3204a5c878c32939094775fb7349f707263

Ah, nevermind then :)

> >> + * This program is distributed in the hope that it will be useful,
> >> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> >> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> >> + * GNU General Public License for more details.
> >> + *
> >> + * You should have received a copy of the GNU General Public License
> >> + * along with this program; if not, write to the Free Software
> >> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
> > These two paragraphs are not needed, and unless you want to track the
> > FSF's office changes for the next 40+ years, I'd really suggest not
> > putting it in there at all.
> >
> 
> Same here, I have reused what I found in other modules. Do you have an
> example of a module with the recommended header?

Just take out these two paragraphs and you should be fine, and be sure
that you really mean "any later" for your license and that you didn't
copy any code from a non "any later" file.

thanks,

greg k-h
