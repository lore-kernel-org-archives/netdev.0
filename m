From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Make ipconfig.c work as a loadable module.
Date: 06 Mar 2003 22:34:16 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1046990052.18158.121.camel@irongate.swansea.linux.org.uk>
References: <Pine.LNX.4.44.0303061500310.31368-100000@mandrake.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robin Holt <holt@sgi.com>
In-Reply-To: <Pine.LNX.4.44.0303061500310.31368-100000@mandrake.americas.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-03-06 at 21:10, Robin Holt wrote:
> The patch at the end of this email makes ipconfig.c work as a loadable 
> module under the 2.5.  The diff was taken against the bitkeeper tree 
> changeset 1.1075.

The right fix is to delete ipconfig.c, it has been the right fix for a long
long time. There are initrd based bootp/dhcp setups that can also then mount
a root NFS partition and they do *not* need any kernel helper.

Indeed probably the biggest distro using nfs root (LTSP) doesn't use ipconfig
even on 2.4. 

DaveM can you just remove the thing. See http://www.ltsp.org for initrds that
don't need it in
