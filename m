From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: WPA IE Attachment
Date: Thu, 27 May 2004 16:21:08 -0400
Sender: prism54-devel-admin@prism54.org
Message-ID: <20040527202108.GA3330@ruslug.rutgers.edu>
References: <00e901c443cd$4b45aa70$0cc8a8c0@navaneeth>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <prism54-devel-admin@prism54.org>
To: prism54-devel@prism54.org
Content-Disposition: inline
In-Reply-To: <00e901c443cd$4b45aa70$0cc8a8c0@navaneeth>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org

On Thu, May 27, 2004 at 05:30:46PM +0800, navaneeth wrote:
> Hi All,
> 
>      I have seen a problem with WPA IE attachment being discussed some time back in the mailing list.
> 
> I am facing the same issue.
> 
> I have done the following:
> 
> 1. Set DOT11_OID_MLMEAUTOLEVEL  to DOT11_MLME_EXTENDED
> 
> 2. Set DOT11_OID_PRIVACYINVOKED to 1.
> 
> 3. Set DOT11_OID_AUTHENABLE to 3 (Both).
> 
> 4. Set DOT11_OID_DEFKEYID to 0.
> 
> 5. Set Key Type for DOT11_OID_DEFKEY1 to 4 as TKIP.
> 
> 6. Generated the following IE
>     dd 16 00 50 f2 01 01 00 00 50 f2 02 01 00 00 50 f2 02 01 00 00 50 f2 02
> 
> 7. Set DOT11_OID_EXUNENCRYPTED to 1.
> 
> 8. Set DOT11_OID_DOT1XENABLE to 1.
> 
> 9. Set DOT11_OID_ATTACHMENT 
>     Type = 0x00  (All Management Frames) . I also tried 0x80 (Beacon Alone)
>     ID     = 0
>     Data  = IE shown above
>     Length = 24 (Length of the above IE)
> 
> But the attachment simply refuses to go in the Beacon. I captured the Beacons . But I failed to see the attachment.

WPA has not been completed. I've started working on it. I'll reply once
I get somewhere.

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
