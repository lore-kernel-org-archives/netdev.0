From: Christoph Hellwig <hch@infradead.org>
Subject: Re: From: Carlos   Mart??n <carlos@cmartin.tk>
Date: Wed, 22 Feb 2006 14:36:04 +0000
Message-ID: <20060222143604.GA16269@infradead.org>
References: <11403021213131-git-send-email-carlos@cmartin.tk> <200602212124.23572.carlos@cmartin.tk> <20060221203211.GA29627@infradead.org> <200602212203.58216.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, acx100-devel@lists.sourceforge.net
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Carlos Mart?n <carlos@cmartin.tk>
Content-Disposition: inline
In-Reply-To: <200602212203.58216.carlos@cmartin.tk>
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Tue, Feb 21, 2006 at 10:03:58PM +0100, Carlos Mart?n wrote:
> > The important bit is that you need the pointers with the above module
> > spit, because you can't call usb- or pci-specific routines from 
> > acx-common.ko 
> 
> Yes, I realise that (unless you export them, but I don't think we want that). 

even that wouldn't work with current module because the usb and pci modules
call into the common code and thus we'd have recursive module depency.

> This approach is probably better even if the driver is unified. Pointer 
> dereferences are cheaper than branches/jumping, aren't they?

It shouldn't matter these days as cpus have nice branch prediction.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
