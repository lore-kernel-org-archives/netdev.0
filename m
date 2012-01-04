From: Greg KH <greg@kroah.com>
Subject: Re: Detected Hardware Unit Hang on Intel Wired
	Ethernet
Date: Wed, 4 Jan 2012 11:22:34 -0800
Message-ID: <20120104192234.GC18214@kroah.com>
References: <CAHM4w1=i5dYy+ReqMO=m6W96CNaQ+O=jw+pKQok0nmjb5-fNAw@mail.gmail.com>
	<4F043190.70405@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Bhavna YADAV <bhavna.yadav@st.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-pci@vger.kernel.org, Shiraz HASHIM <shiraz.hashim@st.com>,
	Deepak SIKRI <deepak.sikri@st.com>
To: Pratyush Anand <pratyush.anand@st.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <4F043190.70405@st.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Jan 04, 2012 at 04:31:36PM +0530, Pratyush Anand wrote:
> Adding PCI mailing list too, as problem is coming only when MSI is enabled.
> 
> If I connect an PCIe analyzer, I see that at the time of issue
> MRd(64) for 32 words has been issued with a wrong 64 bit address
> from ethernet card to my RC.
> In the normal course it always issues MRd(32) only.

Bug in your pcie firmware controller?


------------------------------------------------------------------------------
Ridiculously easy VDI. With Citrix VDI-in-a-Box, you don't need a complex
infrastructure or vast IT resources to deliver seamless, secure access to
virtual desktops. With this all-in-one solution, easily deploy virtual 
desktops for less than the cost of PCs and save 60% on VDI infrastructure 
costs. Try it free! http://p.sf.net/sfu/Citrix-VDIinabox
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
