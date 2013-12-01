From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Subject: Re: [RFC] Fix Free Software Foundation address in file headers
Date: Sun, 01 Dec 2013 19:56:15 +0100
Message-ID: <529B864F.3000206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:45274 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838Ab3LAS4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 13:56:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:

> This came up when John Fastabend got a patch to fix up the headers in
> the drivers/scsi/ directory and so I did a quick search of the network
> drivers and found several instances in the file headers where an old FSF
> address remains.  The old address is:
> 
> 59 Temple Place - Suite 330
> Boston, MA 02111-1307
> 
> The current address is:
> 
> 51 Franklin Street - Fifth Floor
> Boston, MA 02110-1301
> 
> I am wondering whether it may be best to just put a link to the Free
> Software Foundation web page instead of having to update the address any
> time a change is made.
> 
> Either way, I feel the address either needs to get corrected or changed
> to the URL, even though I am not a fan of huge patch series to make
> trivial changes like this.
> 
> Thoughts?

Something like that should be enough:

     [...]
     You should have received a copy of the GNU General Public License along
-    with this program; if not, write to the Free Software Foundation, Inc.,
-    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+    with this program.  If not, see <http://www.gnu.org/licenses/>.
     [...]

This was changed in that form in gpl3.


There are about 3684 references with, at least, 140 variations. Infinite Patience(TM).
